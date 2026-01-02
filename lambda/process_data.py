"""
Event-Driven Data Processing Pipeline
Lambda Function: process_data

This Lambda function is automatically triggered when a file is uploaded
to the raw data S3 bucket. It processes the file and stores the results
in the reports bucket.

Trigger: S3 ObjectCreated event
Input: S3 event notification
Output: Processed data stored in reports bucket
"""

import json
import boto3
import os
from datetime import datetime
from typing import Dict, Any

# Initialize AWS clients
s3_client = boto3.client('s3')
cloudwatch_logs = boto3.client('logs')

# Get environment variables
REPORTS_BUCKET = os.environ.get('REPORTS_BUCKET')
RAW_BUCKET = os.environ.get('RAW_BUCKET')


def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Main Lambda handler function.
    
    Args:
        event: S3 event notification containing bucket and object information
        context: Lambda context object
    
    Returns:
        Dictionary with status code and message
    """
    try:
        # Log the incoming event for debugging
        print(f"Received event: {json.dumps(event)}")
        
        # Extract S3 event details
        # S3 events can have multiple records (batch processing)
        for record in event.get('Records', []):
            # Verify this is an S3 event
            if record.get('eventSource') != 'aws:s3':
                print(f"Skipping non-S3 event: {record.get('eventSource')}")
                continue
            
            # Extract bucket and object key from the event
            bucket_name = record['s3']['bucket']['name']
            object_key = record['s3']['object']['key']
            
            print(f"Processing file: s3://{bucket_name}/{object_key}")
            
            # Get file metadata from S3
            file_metadata = get_file_metadata(bucket_name, object_key)
            
            # Process the file (count records, extract metadata)
            processing_result = process_file(bucket_name, object_key, file_metadata)
            
            # Store processed results to reports bucket
            save_processed_data(processing_result, object_key)
            
            print(f"Successfully processed: {object_key}")
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'File processed successfully',
                'processed_files': len(event.get('Records', []))
            })
        }
    
    except Exception as e:
        # Log error and re-raise for CloudWatch monitoring
        error_message = f"Error processing file: {str(e)}"
        print(f"ERROR: {error_message}")
        print(f"Event: {json.dumps(event)}")
        
        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': 'Error processing file',
                'error': str(e)
            })
        }


def get_file_metadata(bucket_name: str, object_key: str) -> Dict[str, Any]:
    """
    Retrieve metadata about the uploaded file from S3.
    
    Args:
        bucket_name: Name of the S3 bucket
        object_key: Key (path) of the object in S3
    
    Returns:
        Dictionary containing file metadata
    """
    try:
        # Get object metadata
        response = s3_client.head_object(Bucket=bucket_name, Key=object_key)
        
        metadata = {
            'size_bytes': response.get('ContentLength', 0),
            'content_type': response.get('ContentType', 'unknown'),
            'last_modified': response.get('LastModified', '').isoformat() if response.get('LastModified') else '',
            'etag': response.get('ETag', '').strip('"')
        }
        
        print(f"File metadata retrieved: {metadata}")
        return metadata
    
    except Exception as e:
        print(f"Error retrieving metadata: {str(e)}")
        return {
            'size_bytes': 0,
            'content_type': 'unknown',
            'last_modified': '',
            'etag': ''
        }


def process_file(bucket_name: str, object_key: str, metadata: Dict[str, Any]) -> Dict[str, Any]:
    """
    Process the uploaded file and extract information.
    
    This function:
    1. Downloads the file from S3
    2. Counts the number of records (lines for text files)
    3. Extracts processing timestamp
    4. Creates a summary of the processing
    
    Args:
        bucket_name: Name of the S3 bucket
        object_key: Key (path) of the object in S3
        metadata: File metadata dictionary
    
    Returns:
        Dictionary containing processing results
    """
    try:
        # Download file from S3
        print(f"Downloading file: s3://{bucket_name}/{object_key}")
        response = s3_client.get_object(Bucket=bucket_name, Key=object_key)
        file_content = response['Body'].read()
        
        # Count records (for text files, count lines; for JSON, count objects)
        record_count = count_records(file_content, object_key)
        
        # Create processing result
        processing_result = {
            'source_file': object_key,
            'source_bucket': bucket_name,
            'processed_at': datetime.utcnow().isoformat() + 'Z',
            'file_size_bytes': metadata['size_bytes'],
            'content_type': metadata['content_type'],
            'record_count': record_count,
            'processing_status': 'success'
        }
        
        print(f"Processing complete. Records found: {record_count}")
        return processing_result
    
    except Exception as e:
        print(f"Error processing file: {str(e)}")
        return {
            'source_file': object_key,
            'source_bucket': bucket_name,
            'processed_at': datetime.utcnow().isoformat() + 'Z',
            'file_size_bytes': metadata.get('size_bytes', 0),
            'content_type': metadata.get('content_type', 'unknown'),
            'record_count': 0,
            'processing_status': 'error',
            'error_message': str(e)
        }


def count_records(file_content: bytes, object_key: str) -> int:
    """
    Count the number of records in the file.
    
    For text files (CSV, TXT), counts lines.
    For JSON files, counts JSON objects in array or lines.
    For other formats, estimates based on file size.
    
    Args:
        file_content: Raw file content as bytes
        object_key: File name/path for determining file type
    
    Returns:
        Number of records found
    """
    try:
        # Decode file content
        content_str = file_content.decode('utf-8', errors='ignore')
        
        # Determine file type from extension
        file_extension = object_key.lower().split('.')[-1] if '.' in object_key else ''
        
        if file_extension in ['json', 'jsonl']:
            # For JSON files, try to parse and count
            try:
                if file_extension == 'jsonl':
                    # JSONL: one JSON object per line
                    return len([line for line in content_str.strip().split('\n') if line.strip()])
                else:
                    # Regular JSON: try to parse as array
                    data = json.loads(content_str)
                    if isinstance(data, list):
                        return len(data)
                    else:
                        return 1
            except json.JSONDecodeError:
                # If JSON parsing fails, count lines
                return len([line for line in content_str.strip().split('\n') if line.strip()])
        
        elif file_extension in ['csv', 'txt', 'tsv']:
            # For text files, count non-empty lines
            lines = [line for line in content_str.strip().split('\n') if line.strip()]
            # Subtract 1 if first line is header (for CSV)
            if file_extension == 'csv' and len(lines) > 0:
                return max(0, len(lines) - 1)
            return len(lines)
        
        else:
            # For other file types, estimate based on content
            # Count non-empty lines as a fallback
            lines = [line for line in content_str.strip().split('\n') if line.strip()]
            return len(lines) if lines else 1
    
    except Exception as e:
        print(f"Error counting records: {str(e)}")
        # Fallback: estimate based on file size (rough estimate)
        return max(1, len(file_content) // 100)


def save_processed_data(processing_result: Dict[str, Any], original_key: str) -> None:
    """
    Save the processed data to the reports S3 bucket.
    
    Args:
        processing_result: Dictionary containing processing results
        original_key: Original S3 object key (for naming the output file)
    """
    try:
        # Create output file name with timestamp
        timestamp = datetime.utcnow().strftime('%Y%m%d_%H%M%S')
        base_name = original_key.split('/')[-1]  # Get filename without path
        output_key = f"processed/{timestamp}_{base_name}_processed.json"
        
        # Convert processing result to JSON
        json_content = json.dumps(processing_result, indent=2)
        
        # Upload to reports bucket
        print(f"Saving processed data to: s3://{REPORTS_BUCKET}/{output_key}")
        s3_client.put_object(
            Bucket=REPORTS_BUCKET,
            Key=output_key,
            Body=json_content.encode('utf-8'),
            ContentType='application/json'
        )
        
        print(f"Processed data saved successfully: {output_key}")
    
    except Exception as e:
        print(f"Error saving processed data: {str(e)}")
        raise

