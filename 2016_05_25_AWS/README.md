# Introduction to Machine Learning with H2O and AWS

---

### Event Information

Event: [Galvanize Seattle](http://www.eventbrite.com/e/seattle-data-science-applications-of-h2oai-and-aws-tickets-24436649677)

Date: May 25, 2016

Place: Galvanize Seattle – Pioneer Square, 111 South Jackson Street, Seattle, WA 98104

Speaker: Navdeep Gill

---

### Content

H2O is an open source, distributed machine learning platform designed for big data, with the added benefit that it’s easy to use on a laptop in addition to a multi-node cluster.  The core machine learning algorithms of H2O are implemented in high-performance Java, however, fully-featured APIs are available in R, Python, Scala, REST/JSON, and also through a web interface.

Since H2O’s algorithm implementations are distributed, this allows the software to scale to very large datasets that may not fit into RAM on a single machine. H2O currently features distributed implementations of Generalized Linear Models, Gradient Boosting Machines, Random Forest, Deep Neural Nets, dimensionality reduction methods (PCA, GLRM), clustering algorithms (K-means), anomaly detection methods, among others.

H2O was built with commodity, CPU-based, hardware in mind. With that said, many H2O users choose Amazon AWS as the platform to train and host their machine learning models.  The benefit of this is users can take advantage of H2O’s distributed nature and the ease of AWS, which then outputs results frequently and accurately across huge datasets.
In this talk we will demonstrate the following applications of H2O and Amazon AWS:

1) How to start up a multi-node H2O cluster on EC2, and train (with a few lines of R or Python code or through the H2O web GUI), distributed machine learning algorithms. 

2) Develop a machine learning application with the tandem use of H2O and AWS Lambda, a compute service that runs code – A Lambda function – on demand. AWS Lambda simplifies the process of running code in the cloud by managing compute resource automatically.

3) Showcase the use of H2O Sparkling Water within Amazon EMR (Elastic MapReduce), a web service that makes it easy to quickly and cost-effectively process vast amounts of data. Amazon EMR simplifies big data processing, providing a managed Hadoop framework that makes it easy, fast, and cost-effective for you to distribute and process vast amounts of your data across dynamically scalable Amazon EC2 instances.

