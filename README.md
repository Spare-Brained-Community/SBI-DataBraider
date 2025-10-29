# Data Braider

![Data Braider Logo](./SBIDataBraider_APP/logo/AppSource-SBIDataBraider-350x350.png)

## Overview

**Data Braider** is a powerful Microsoft Dynamics 365 Business Central extension that enables power users, implementors, and administrators to configure and expose custom API datasets as JSON. This flexible solution bridges Business Central data with external systems, enabling seamless integrations and data access.

Published by **Stefan Maron Consulting**, Data Braider transforms how you share Business Central data with external applications, reporting tools, and integration platforms.

## Key Features

### 🚀 Flexible API Endpoints
- **Create Custom API Endpoints**: Configure multiple API endpoints to expose Business Central data
- **Read and Write Operations**: Support for both read-only and write-enabled endpoints
- **RESTful API**: Standard REST API following Microsoft Dynamics 365 Business Central conventions
- **OData Support**: Full OData v4 compatibility for querying and filtering

### 📊 Multiple Output Formats
- **Hierarchical JSON**: Structured nested data ideal for complex integrations
- **Flat JSON**: Simplified output perfect for Power Platform, Power BI, and other analytics tools

### ⚙️ Advanced Configuration
- **Table and Field Selection**: Choose exactly which tables and fields to expose
- **Custom Filtering**: Apply filters to control data visibility and access
- **Pagination Support**: Built-in pagination for large datasets
- **Delta Read**: Support for incremental data synchronization

### 🔐 Enterprise-Ready
- **Licensing Integration**: Built-in license management and validation
- **Performance Monitoring**: Track API call duration for performance optimization
- **Error Handling**: Comprehensive error logging and management
- **Enable/Disable Controls**: Granular control over endpoint availability

### 🔌 Integration Capabilities
- **Import/Export Configuration**: Share endpoint configurations across environments
- **Template Support**: Reusable configuration templates
- **Variables Support**: Dynamic configuration with variables
- **API Accelerators**: Pre-built configurations for common scenarios

## Installation

### Prerequisites
- Microsoft Dynamics 365 Business Central (Cloud or On-Premises)
- Business Central version 24.0 or later
- Platform version 1.0 or later

### Install from AppSource
1. Navigate to Microsoft AppSource
2. Search for "Data Braider"
3. Click **Get it now**
4. Follow the installation wizard for your Business Central environment

### Install from GitHub Release
1. Download the latest `.app` file from the [Releases](https://github.com/Spare-Brained-Community/SBI-DataBraider/releases) page
2. In Business Central, navigate to **Extension Management**
3. Click **Upload Extension**
4. Select the downloaded `.app` file and complete the installation

## Getting Started

### 1. Access Data Braider

After installation, search for **Data Braider API Endpoints** in Business Central to access the configuration page.

### 2. Create Your First API Endpoint

1. Click **+ New** to create a new endpoint configuration
2. Fill in the following fields:
   - **Code**: Unique identifier for the endpoint (used in the API URL)
   - **Description**: A descriptive name for your reference
   - **Endpoint Type**: Choose between Read-Only or Write-Enabled
   - **Output JSON Type**: Select Hierarchical or Flat format
3. **Enable** the endpoint

### 3. Configure Tables and Fields

1. In the endpoint configuration, add **Lines** to specify which tables to include
2. For each table line:
   - Select the **Table** to expose
   - Choose which **Fields** to include
   - Configure any **Filters** or relationships

### 4. Test Your API Endpoint

Your endpoint will be available at:
```
https://[your-bc-instance]/api/sparebrained/databraider/v2.0/companies([company-id])/read?$filter=code eq '[your-code]'
```

Replace:
- `[your-bc-instance]`: Your Business Central URL
- `[company-id]`: Your company GUID
- `[your-code]`: The Code you assigned to your endpoint

## API Reference

### Read API Endpoint

**Base URL**: `/api/sparebrained/databraider/v2.0/companies([company-id])/read`

#### Parameters
- `code` (required): The endpoint configuration code
- `filterJson` (optional): JSON object containing filter criteria
- `pageStart` (optional): Starting page number for pagination
- `pageSize` (optional): Number of records per page

#### Response Fields
- `code`: The endpoint code
- `description`: Endpoint description
- `endpointType`: Type of endpoint (Read/Write)
- `outputJSONType`: JSON format (Hierarchical/Flat)
- `jsonResult`: The actual data payload
- `topLevelRecordCount`: Number of top-level records returned
- `includedRecordCount`: Total number of records included

### Write API Endpoint

**Base URL**: `/api/sparebrained/databraider/v2.0/companies([company-id])/write`

#### Request Body
```json
{
  "code": "YOUR_ENDPOINT_CODE",
  "jsonInput": {
    // Your data to write
  }
}
```

#### Response
- `jsonResult`: Result of the write operation

## Configuration Options

### Endpoint Types
- **Read-Only**: Allows data retrieval only
- **Write-Enabled**: Supports data creation and modification

### Output Formats
- **Hierarchical**: Nested JSON structure preserving table relationships
- **Flat**: Single-level JSON array, ideal for reporting and analytics tools

### Advanced Features
- **Import/Export**: Share configurations between environments
- **Copy Configuration**: Duplicate existing configurations quickly
- **Variables**: Use dynamic values in your configurations
- **Templates**: Create reusable configuration patterns
- **Logging**: Track API usage and performance

## Performance Optimization

- Monitor **Last Run Duration** in the endpoint list to identify slow endpoints
- Use filters to limit data retrieval
- Implement pagination for large datasets
- Consider using delta read for incremental synchronization
- Test with flat JSON format for better performance in reporting scenarios

## Support and Community

### Documentation
- [GitHub Issues](https://github.com/Spare-Brained-Community/SBI-DataBraider/issues) - Bug reports and feature requests
- Context-sensitive help available within Business Central

### Community
This project is maintained by the **Spare Brained Community** as a continuation of the former Spare Brained Ideas company. We welcome contributions and feedback from partners and users.

### Security
For security vulnerabilities, please follow the [Security Policy](./SECURITY.md) and report issues to the Microsoft Security Response Center.

### Getting Help
If you encounter issues or have questions:
1. Check the [Issues](https://github.com/Spare-Brained-Community/SBI-DataBraider/issues) page
2. Review existing documentation
3. Create a new issue with detailed information about your problem

## Contributing

We welcome contributions from the community! This repository is part of the Spare Brained Community initiative, making the source code available for partners and contributors.

### Development Setup
1. Clone the repository
2. Open `DataBraider.code-workspace` in Visual Studio Code
3. Ensure you have the AL Language extension installed
4. Build and test your changes

### Submitting Changes
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request with a clear description

## License

This project includes source code made available for partners of the former Spare Brained Ideas company and the Spare Brained Community.

- **Publisher**: Stefan Maron Consulting
- **Privacy Statement**: https://stefanmaron.com/privacystatement/
- **EULA**: https://stefanmaron.com/eula/

## Acknowledgments

Data Braider is built on Microsoft Dynamics 365 Business Central platform and follows AL-Go for GitHub workflows for continuous integration and deployment.

Special thanks to the Spare Brained Ideas company and all contributors who have made this project possible.

## Version Information

- **Current Version**: 2.3.0.0
- **API Version**: v2.0
- **Runtime**: 13.0
- **Application**: 24.0.0.0
- **Platform**: 1.0.0.0

## Links

- **GitHub Repository**: https://github.com/Spare-Brained-Community/SBI-DataBraider
- **Publisher Website**: https://stefanmaron.com
- **Issue Tracking**: https://github.com/Spare-Brained-Community/SBI-DataBraider/issues

---

Making this app source code quickly available for Partners of the former Spare Brained Ideas company.

Made with ❤️ by the Spare Brained Community
