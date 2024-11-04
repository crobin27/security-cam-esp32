const AWS = require('aws-sdk')
const dynamoDB = new AWS.DynamoDB.DocumentClient()

exports.handler = async (event) => {
  console.log('Event received:', JSON.stringify(event, null, 2))

  const bucketName = process.env.BUCKET_NAME
  const tableName = process.env.TABLE_NAME

  for (const record of event.Records) {
    const key = record.s3.object.key
    const fileSize = record.s3.object.size || 0 // Default to 0 if undefined
    const eventTime = record.eventTime || new Date().toISOString() // Default to current time

    const params = {
      TableName: tableName,
      Item: {
        unique_id: key, // Use the S3 key as a unique identifier
        file_size: fileSize,
        date_uploaded: eventTime,
        filename: key,
      },
    }

    try {
      await dynamoDB.put(params).promise()
      console.log(
        `Successfully inserted metadata for file ${key} into DynamoDB`
      )
    } catch (error) {
      console.error(`Error inserting metadata for file ${key}:`, error)
      console.error(`Params: ${JSON.stringify(params)}`) // Log parameters for further diagnosis
    }
  }

  return {
    statusCode: 200,
    body: JSON.stringify({ message: 'Successfully processed S3 event.' }),
  }
}
