import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import FunderPage from './funder';

describe('Funder', () => {
  it('renders the title', () => {
    render(<FunderPage />);
    const funder_text = screen.getByText("Project: Funder");
    expect(funder_text).toBeInTheDocument()
  });
});
