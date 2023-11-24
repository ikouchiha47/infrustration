Name:           talon-server
Version:        1.0
Release:        1%{?dist}
Summary:        My Golang Application
License:        MIT
URL:            https://example.com/my-app
Source0:        https://example.com/my-app/releases/download/v1.0/my-app-1.0.tar.gz

BuildRequires:  golang

%description
My Golang Application

%prep
%autosetup -n my-app-1.0

%build
# Build your Golang application
export GOPATH=%{_builddir}/%{name}-%{version}
mkdir -p $GOPATH
cp -r . $GOPATH
cd $GOPATH/src/my-app
go build -o %{name}

%install
# Install the binary
install -Dm 755 %{name} %{buildroot}/%{_bindir}/%{name}

%files
%{_bindir}/%{name}

