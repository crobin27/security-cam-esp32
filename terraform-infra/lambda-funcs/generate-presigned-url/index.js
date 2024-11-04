const AWS = require('aws-sdk')
const { v4: uuidv4 } = require('uuid') // Using UUID for unique filenames
const s3 = new AWS.S3()

exports.handler = async (event) => {
  const bucketName = process.env.BUCKET_NAME

  // Generate a unique filename for the image
  const uniqueFilename = `images/${uuidv4()}.jpg`

  try {
    const url = s3.getSignedUrl('putObject', {
      Bucket: bucketName,
      Key: uniqueFilename,
      Expires: 300, // URL expires in 5 minutes
    })

    return {
      statusCode: 200,
      body: JSON.stringify({
        url: url,
        filename: uniqueFilename, // Returning filename to help track in DynamoDB
      }),
    }
  } catch (error) {
    console.error('Error generating presigned URL', error)
    return {
      statusCode: 500,
      body: JSON.stringify({ message: 'Could not generate presigned URL' }),
    }
  }
}
