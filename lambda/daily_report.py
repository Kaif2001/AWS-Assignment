"""
Event-Driven Data Processing Pipeline
Lambda Function: daily_report

This Lambda function is automatically triggered once per day by EventBridge
to generate a summary report of all processed data.

Trigger: EventBridge scheduled rule (daily at 00:00 UTC)
Input: EventBridge event
Output: Daily summary report stored in reports bucket
"""

import json
import boto3
import os
from datetime import datetime, timedelta
from typing import Dict, Any, List
from collections import defaultdict

# Initialize AWS clients
s3_client = boto3.client('s3')

# Get environment variables
REPORTS_BUCKET = os.environ.get('REPORTS_BUCKET')


def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Main Lambda handler function for daily report generation.
    
    Args:
        event: EventBridge event (scheduled trigger)
        context: Lambda context object
    
    Returns:
        Dictionary with status code and message
    """
    try:
        print(f"Daily report generation started at {datetime.utcnow().isoformat()}")
        print(f"Received event: {json.dumps(event)}")
        
        # Get the date for the report (yesterday's date, as we're generating at midnight)
        report_date = (datetime.utcnow() - timedelta(days=1)).date()
        report_date_str = report_date.isoformat()
        
        print(f"Generating report for date: {report_date_str}")
        
        # Collect all processed files from the reports bucket
        processed_files = collect_processed_files(report_date_str)
        
        # Generate summary statistics
        summary = generate_summary(processed_files, report_date_str)
        
        # Save the daily report to S3
        report_key = save_daily_report(summary, report_date_str)
        
        print(f"Daily report generated successfully: {report_key}")
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Daily report generated successfully',
                'report_date': report_date_str,
                'report_location': f"s3://{REPORTS_BUCKET}/{report_key}",
                'total_files_processed': summary['total_files'],
                'total_records': summary['total_records']
            })
        }
    
    except Exception as e:
        error_message = f"Error generating daily report: {str(e)}"
        print(f"ERROR: {error_message}")
        print(f"Event: {json.dumps(event)}")
        
        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': 'Error generating daily report',
                'error': str(e)
            })
        }


def collect_processed_files(report_date: str) -> List[Dict[str, Any]]:
    """
    Collect all processed files from the reports bucket for the given date.
    
    Args:
        report_date: Date string in YYYY-MM-DD format
    
    Returns:
        List of processed file metadata dictionaries
    """
    processed_files = []
    
    try:
        # List all objects in the processed/ prefix
        print(f"Scanning reports bucket: {REPORTS_BUCKET}")
        paginator = s3_client.get_paginator('list_objects_v2')
        
        for page in paginator.paginate(Bucket=REPORTS_BUCKET, Prefix='processed/'):
            if 'Contents' not in page:
                continue
            
            for obj in page['Contents']:
                object_key = obj['Key']
                
                # Check if this file was processed on the report date
                # Files are named with timestamp: YYYYMMDD_HHMMSS_filename_processed.json
                if report_date.replace('-', '') in object_key:
                    try:
                        # Download and parse the processed file
                        response = s3_client.get_object(Bucket=REPORTS_BUCKET, Key=object_key)
                        file_content = response['Body'].read().decode('utf-8')
                        processed_data = json.loads(file_content)
                        
                        processed_files.append(processed_data)
                        print(f"Collected file: {object_key}")
                    
                    except Exception as e:
                        print(f"Error reading file {object_key}: {str(e)}")
                        continue
        
        print(f"Total processed files collected: {len(processed_files)}")
        return processed_files
    
    except Exception as e:
        print(f"Error collecting processed files: {str(e)}")
        return []


def generate_summary(processed_files: List[Dict[str, Any]], report_date: str) -> Dict[str, Any]:
    """
    Generate summary statistics from processed files.
    
    Args:
        processed_files: List of processed file metadata dictionaries
        report_date: Date string in YYYY-MM-DD format
    
    Returns:
        Dictionary containing summary statistics
    """
    if not processed_files:
        return {
            'report_date': report_date,
            'generated_at': datetime.utcnow().isoformat() + 'Z',
            'total_files': 0,
            'total_records': 0,
            'total_size_bytes': 0,
            'files_by_type': {},
            'processing_status': {
                'success': 0,
                'error': 0
            },
            'message': 'No files processed on this date'
        }
    
    # Initialize summary counters
    total_records = 0
    total_size_bytes = 0
    files_by_type = defaultdict(int)
    processing_status = defaultdict(int)
    
    # Aggregate statistics
    for file_data in processed_files:
        total_records += file_data.get('record_count', 0)
        total_size_bytes += file_data.get('file_size_bytes', 0)
        
        content_type = file_data.get('content_type', 'unknown')
        files_by_type[content_type] += 1
        
        status = file_data.get('processing_status', 'unknown')
        processing_status[status] += 1
    
    # Build summary report
    summary = {
        'report_date': report_date,
        'generated_at': datetime.utcnow().isoformat() + 'Z',
        'total_files': len(processed_files),
        'total_records': total_records,
        'total_size_bytes': total_size_bytes,
        'total_size_mb': round(total_size_bytes / (1024 * 1024), 2),
        'files_by_type': dict(files_by_type),
        'processing_status': dict(processing_status),
        'average_records_per_file': round(total_records / len(processed_files), 2) if processed_files else 0,
        'average_file_size_bytes': round(total_size_bytes / len(processed_files), 2) if processed_files else 0,
        'files_processed': [
            {
                'source_file': f.get('source_file', 'unknown'),
                'record_count': f.get('record_count', 0),
                'file_size_bytes': f.get('file_size_bytes', 0),
                'processed_at': f.get('processed_at', 'unknown')
            }
            for f in processed_files
        ]
    }
    
    print(f"Summary generated: {summary['total_files']} files, {summary['total_records']} records")
    return summary


def save_daily_report(summary: Dict[str, Any], report_date: str) -> str:
    """
    Save the daily summary report to the reports S3 bucket.
    
    Args:
        summary: Summary dictionary containing report data
        report_date: Date string in YYYY-MM-DD format
    
    Returns:
        S3 key where the report was saved
    """
    try:
        # Create report file name
        report_key = f"daily-reports/{report_date}_daily_summary.json"
        
        # Convert summary to JSON with pretty formatting
        json_content = json.dumps(summary, indent=2)
        
        # Upload to reports bucket
        print(f"Saving daily report to: s3://{REPORTS_BUCKET}/{report_key}")
        s3_client.put_object(
            Bucket=REPORTS_BUCKET,
            Key=report_key,
            Body=json_content.encode('utf-8'),
            ContentType='application/json',
            Metadata={
                'report-date': report_date,
                'generated-at': summary['generated_at']
            }
        )
        
        print(f"Daily report saved successfully: {report_key}")
        return report_key
    
    except Exception as e:
        print(f"Error saving daily report: {str(e)}")
        raise

