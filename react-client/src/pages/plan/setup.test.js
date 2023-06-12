import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import PlanSetupPage from './setup.js';

describe('Dashboard', () => {
  it('renders the title', () => {
    render(<PlanSetupPage />);
    const setup_text = screen.getByText("Plan Setup");
    expect(setup_text).toBeInTheDocument()
  });
});
